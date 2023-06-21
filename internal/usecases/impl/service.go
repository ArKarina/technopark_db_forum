package impl

import (
	"technopark_db_forum/internal/models"
	"technopark_db_forum/internal/repositories"
	"technopark_db_forum/internal/usecases"
)

type ServiceUseCaseImpl struct {
	serviceRepository repositories.ServiceRepository
}

func CreateServiceUseCase(serviceRepository repositories.ServiceRepository) usecases.ServiceUseCase {
	return &ServiceUseCaseImpl{serviceRepository: serviceRepository}
}

func (serviceUseCase *ServiceUseCaseImpl) Clear() (err error) {
	return serviceUseCase.serviceRepository.Clear()
}

func (serviceUseCase *ServiceUseCaseImpl) GetStatus() (status *models.Status, err error) {
	return serviceUseCase.serviceRepository.GetStatus()
}
