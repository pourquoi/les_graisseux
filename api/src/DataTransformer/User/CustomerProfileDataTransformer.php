<?php

namespace App\DataTransformer\User;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use App\Dto\User\CustomerProfile;
use App\Entity\Customer;
use App\Repository\CustomerRepository;
use App\Repository\ServiceTreeRepository;
use App\Repository\UserRepository;
use Symfony\Component\Security\Core\Security;

class CustomerProfileDataTransformer implements DataTransformerInterface
{
    private $security;
    private $userRepository;
    private $customerRepository;
    private $serviceRepository;

    public function __construct(Security $security, UserRepository $userRepository, CustomerRepository $customerRepository, ServiceTreeRepository $serviceRepository)
    {
        $this->security = $security;
        $this->userRepository = $userRepository;
        $this->customerRepository = $customerRepository;
        $this->serviceRepository = $serviceRepository;
    }

    /**
     * @param CustomerProfile $profile
     * @param string $to
     * @param array $context
     * @return object|void
     */
    public function transform($profile, string $to, array $context = [])
    {
        if ($profile->user && $this->security->isGranted('ROLE_ADMIN')) {
            $user = $this->userRepository->find($profile->user);
        } else {
            $user = $this->security->getUser();
        }

        if (null === $user)
            throw new \InvalidArgumentException(sprintf('Error creating customer: user %d not found', $profile->user));

        if ($user->getCustomer()) {
            $customer = $user->getMechanic();
        } else {
            $customer = new Customer();
            $customer->setUser($user);
        }

        return $customer;
    }

    public function supportsTransformation($data, string $to, array $context = []): bool
    {
        if ($data instanceof Customer) {
            return false;
        }

        return $to === Customer::class && null !== ($context['input']['class'] ?? null);
    }

}