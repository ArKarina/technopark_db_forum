create extension if not exists citext;

create unlogged table if not exists users (
    nickname citext collate "ucs_basic" not null primary key,
    fullname text not null,
    about text,
    email citext not null unique
);

create unlogged table if not exists forums (
    title text not null,
    user_admin citext not null references users(nickname),
    slug citext not null primary key,
    posts bigint default 0,
    threads int default 0
);

create unlogged table if not exists threads (
    id bigserial not null primary key,
    title text not null,
    author citext not null references users(nickname),
    forum citext not null references forums(slug),
    message text not null,
    votes int default 0,
    slug citext,
    created timestamp with time zone default now()
);

create unlogged table if not exists posts (
    id bigserial not null primary key,
    parent int references posts(id) default 0,
    author citext not null references users(nickname),
    message text not null,
    is_edited bool default false,
    forum citext not null references forums(slug),
    thread int not null references threads(id),
    created timestamp with time zone default now(),
    path bigint[] default array []::integer[]
);

create unlogged table if not exists votes (
    nickname citext not null references users(nickname),
    thread int not null references threads(id),
    voice int not null,
    unique (nickname, thread)
);

create unlogged table if not exists forum_users (
    nickname citext collate "ucs_basic" not null references users(nickname),
    forum citext not null references forums(slug),
    unique (nickname, forum)
);


-- Обновление количества веток на форуме при создании новой
create or replace function after_insert_threads() returns trigger as
$$
begin
    update forums
    set threads = forums.threads + 1
    where slug = NEW.forum;
    return NEW;
end;
$$ language plpgsql;

create trigger insert_threads
after insert on threads for each row execute procedure after_insert_threads();


-- Обновление пути к посту
create or replace function before_insert_post() returns trigger as
$$ declare parent_post_id posts.id%type := 0; --может убрать declare
begin
    NEW.path = (select path from posts where id = new.parent) || NEW.id;
    return NEW;
end;
$$ language plpgsql;

create trigger insert_post_before
before insert on posts for each row execute procedure before_insert_post();

-- Обновление количества постов на форуме при создании нового
create or replace function after_insert_post() returns trigger as
$$
begin
    update forums
    set posts = forums.posts + 1
    where slug = NEW.forum;
    return NEW;
end;
$$ language plpgsql;

create trigger insert_post_after
after insert on posts for each row execute procedure after_insert_post();


-- Добавление пользователя к форуму
create or replace function add_user() returns trigger as
$$
begin
    insert into forum_users (nickname, forum)
    values (NEW.author, NEW.forum) on conflict do nothing;
    return NEW;
end;
$$ language plpgsql;

create trigger insert_thread_add_forum_user
after insert on threads for each row execute procedure add_user();

create trigger insert_post_add_forum_user
after insert on posts for each row execute procedure add_user();


-- Обновление рейтинга thread после cоздания vote
create or replace function insert_thread_votes() returns trigger as
$$
begin
    update threads
    set votes = threads.votes + NEW.voice
    where id = NEW.thread;
    return NEW;
end;
$$ language plpgsql;

create trigger insert_vote
after insert on votes for each row execute procedure insert_thread_votes();


-- Обновление рейтинга thread после изменения vote
create or replace function update_thread_votes() returns trigger as
$$
begin
    update threads
    set votes = threads.votes + NEW.voice - OLD.voice
    where id = NEW.thread;
    return NEW;
end;
$$ language plpgsql;

create trigger update_vote
after update on votes for each row execute procedure update_thread_votes();


-- INDEXES
create index if not exists index_users_nickname_email on users (nickname, email);

--create index if not exists user_forum_forum on forum_users (forum);
create index if not exists index_user_forum_nickname on forum_users (nickname);
create index if not exists index_user_forum on forum_users (forum, nickname);

--create index if not exists threads_slug on threads (forum);
create index if not exists index_threads_created on threads (created);
create index if not exists index_threads_forum_created on threads (forum, created);

--create index if not exists posts_id_thread on posts (thread, id);
create index if not exists index_posts_id_thread on posts (thread, id, parent NULLS FIRST);
create index if not exists index_posts_id_path_first on posts (path, (path[1]), id);
--create index if not exists posts_path_path1 on posts (path, (path[1]));
create index if not exists index_posts_id_thread_parent_first on posts ((path[1]), thread, id, parent NULLS FIRST);
--create index if not exists posts_thread on posts (thread);
create index if not exists index_posts_thread_path on posts (thread, path);

create unique index if not exists index_votes_key on votes (thread, nickname);

-- Индексы
-- CREATE INDEX IF NOT EXISTS index_users_nickname ON users USING HASH(nickname);
-- CREATE INDEX IF NOT EXISTS index_users_email ON users USING HASH(email);
-- CREATE INDEX IF NOT EXISTS index_users_email_nickname ON users (email, nickname);

-- CREATE INDEX IF NOT EXISTS index_forums_slug ON forums USING HASH(slug);

-- CREATE INDEX IF NOT EXISTS index_forum_users_forum_user_nickname ON forum_users (forum_slug, nickname);

-- CREATE INDEX IF NOT EXISTS index_threads_slug ON threads USING HASH(slug);
-- CREATE INDEX IF NOT EXISTS index_threads_forum_CREATEd ON threads (forum_slug, created);

-- CREATE INDEX IF NOT EXISTS index_posts_thread_id ON posts (thread_id, id);
-- CREATE INDEX IF NOT EXISTS index_posts_path_tree ON posts (path_tree);
-- CREATE INDEX IF NOT EXISTS index_posts_thread_post_tree ON posts (thread_id, path_tree);
-- CREATE INDEX IF NOT EXISTS index_posts_parent_thread_id ON posts (parent_id, thread_id, id);
-- CREATE INDEX IF NOT EXISTS index_posts_post_tree_one_post_tree ON posts ((path_tree[1]), path_tree);


