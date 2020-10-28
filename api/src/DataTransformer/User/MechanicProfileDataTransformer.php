<?php

namespace App\DataTransformer\User;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use ApiPlatform\Core\Serializer\AbstractItemNormalizer;
use App\Dto\User\MechanicProfile;
use App\Entity\Mechanic;
use App\Repository\MechanicRepository;
use App\Repository\ServiceTreeRepository;
use App\Repository\UserRepository;
use Doctrine\Common\Collections\Criteria;
use Symfony\Component\Security\Core\Security;

class MechanicProfileDataTransformer implements DataTransformerInterface
{
    private $security;
    private $userRepository;
    private $mechanicRepository;
    private $serviceRepository;

    public function __construct(Security $security, UserRepository $userRepository, MechanicRepository $mechanicRepository, ServiceTreeRepository $serviceRepository)
    {
        $this->security = $security;
        $this->userRepository = $userRepository;
        $this->mechanicRepository = $mechanicRepository;
        $this->serviceRepository = $serviceRepository;
    }

    /**
     * @param MechanicProfile $profile
     * @param string $to
     * @param array $context
     * @return object|void
     */
    public function transform($profile, string $to, array $context = [])
    {
        if ($profile->user && $this->security->isGranted('ROLE_ADMIN')) {
            $user = $profile->user;
        } else {
            $user = $this->security->getUser();
        }

        if (null === $user)
            throw new \InvalidArgumentException(sprintf('Error creating mechanic: user %d not found', $profile->user));

        if ($user->getMechanic()) {
            $mechanic = $user->getMechanic();
        } else {
            $mechanic = new Mechanic();
            $mechanic->setUser($user);
        }

        $mechanic->setAbout($profile->about);

        if (null !== $profile->services) {
            $mechanic->getServices()->clear();
            if(count($profile->services) > 0) {
                foreach ($profile->services as $service) {
                    $mechanic->addService($service);
                }
            }
        }

        if ($profile->address) {
            $user->setAddress(clone $profile->address);
        }

        return $mechanic;
    }

    public function supportsTransformation($data, string $to, array $context = []): bool
    {
        if ($data instanceof Mechanic) {
            return false;
        }

        return $to === Mechanic::class && null !== ($context['input']['class'] ?? null);
    }


}