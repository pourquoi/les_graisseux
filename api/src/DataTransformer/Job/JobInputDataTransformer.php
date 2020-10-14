<?php

namespace App\DataTransformer\Job;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use App\Dto\Job\JobInput;
use App\Entity\Job;
use App\Entity\User;
use App\Repository\CustomerRepository;
use App\Repository\CustomerVehicleRepository;
use App\Repository\VehicleTreeRepository;
use Symfony\Component\Security\Core\Security;

class JobInputDataTransformer implements DataTransformerInterface
{
    private $security;
    private $customerRepository;
    private $customerVehicleRepository;

    public function __construct(Security $security, CustomerRepository $customerRepository, CustomerVehicleRepository $customerVehicleRepository )
    {
        $this->security = $security;
        $this->customerRepository = $customerRepository;
        $this->customerVehicleRepository = $customerVehicleRepository;
    }

    /**
     * @param JobInput $data
     * @param string $to
     * @param array $context
     * @return object|void
     */
    public function transform($data, string $to, array $context = [])
    {
        /** @var User $currentUser */
        $currentUser = $this->security->getUser();

        if ($this->security->isGranted('ROLE_ADMIN') && $data->customer !== null) {
            $customer = $this->customerRepository->find($data->customer);
        } else {
            $customer = $currentUser->getCustomer();
        }

        if ($customer === null) {
            throw new \InvalidArgumentException();
        }

        $vehicle = null;
        if ($data->vehicle) {
            $vehicle = $this->customerVehicleRepository->find($data->vehicle);
            if ($vehicle->getCustomer() !== $customer) {
                throw new \InvalidArgumentException();
            }
        }

        $job = new Job();
        $job->setTitle($data->title);
        $job->setDescription($data->description);
        $job->setCustomer($customer);
        $job->setVehicle($vehicle);

        if (null !== $data->address) {
            $job->setAddress(clone $data->address);
        } else if ($customer->getUser()->getAddress() !== null) {
            $job->setAddress($customer->getUser()->getAddress());
        }

        return $job;
    }

    public function supportsTransformation($data, string $to, array $context = []): bool
    {
        if ($data instanceof Job) {
            return false;
        }

        return $to === Job::class && null !== ($context['input']['class'] ?? null);
    }


}