<?php

namespace App\DataTransformer\Job;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use ApiPlatform\Core\Serializer\AbstractItemNormalizer;
use ApiPlatform\Core\Validator\ValidatorInterface;
use App\Dto\Job\JobInput;
use App\Entity\Customer;
use App\Entity\Job;
use App\Entity\User;
use App\Repository\CustomerRepository;
use App\Repository\CustomerVehicleRepository;
use App\Repository\VehicleTreeRepository;
use Symfony\Component\Security\Core\Security;

class JobInputDataTransformer implements DataTransformerInterface
{
    private $validator;
    private $security;
    private $customerRepository;
    private $customerVehicleRepository;

    public function __construct(ValidatorInterface $validator, Security $security, CustomerRepository $customerRepository, CustomerVehicleRepository $customerVehicleRepository )
    {
        $this->validator = $validator;
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
        $this->validator->validate($data);

        $customer = null;

        if (isset($context[AbstractItemNormalizer::OBJECT_TO_POPULATE])) {
            $job = $context[AbstractItemNormalizer::OBJECT_TO_POPULATE];
            $customer = $job->getCustomer();
        } else {
            $job = new Job();
        }

        /** @var User $currentUser */
        $currentUser = $this->security->getUser();

        if ($customer === null) {
            if ($this->security->isGranted('ROLE_ADMIN') && $data->customer !== null) {
                $customer = $data->customer;

                if ($customer === null) {
                    throw new \InvalidArgumentException();
                }
            } else {
                $customer = $currentUser->getCustomer();
                if ($customer === null) {
                    $customer = new Customer();
                    $customer->setUser($currentUser);
                    $currentUser->setCustomer($customer);
                }
            }
        }

        $vehicle = null;
        if ($data->vehicle) {
            $vehicle = $data->vehicle;
            if ($vehicle->getCustomer() === null) {
                $vehicle->setCustomer($customer);
            } else if ($vehicle->getCustomer() !== $customer) {
                throw new \InvalidArgumentException();
            }
        }

        $job->setTitle($data->title);
        $job->setDescription($data->description);
        $job->setCustomer($customer);
        $job->setVehicle($vehicle);

        if (null !== $data->address) {
            $job->setAddress(clone $data->address);
        } else if ($customer->getUser()->getAddress() !== null) {
            $job->setAddress($customer->getUser()->getAddress());
        }

        if ($data->tasks !== null ) {
            $job->getTasks()->clear();
            if (count($data->tasks) > 0) {
                foreach ($data->tasks as $task) {
                    $job->addTask($task);
                }
            }
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