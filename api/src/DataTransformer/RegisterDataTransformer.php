<?php

namespace App\DataTransformer;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use ApiPlatform\Core\Validator\ValidatorInterface;
use App\Entity\User;
use App\Repository\UserRepository;
use Symfony\Component\Security\Core\Encoder\UserPasswordEncoderInterface;
use App\Dto;

class RegisterDataTransformer implements DataTransformerInterface
{
    private $userRepository;
    private $validator;
    private $passwordEncoder;

    public function __construct(ValidatorInterface $validator, UserRepository $userRepository, UserPasswordEncoderInterface $passwordEncoder)
    {
        $this->validator = $validator;
        $this->userRepository = $userRepository;
        $this->passwordEncoder = $passwordEncoder;
    }

    /**
     * @param Dto\Input\Register $data
     * @param string $to
     * @param array $context
     * @return User
     */
    public function transform($data, string $to, array $context = [])
    {
        $this->validator->validate($data);

        $user = new User();
        $user->setEmailVerificationRequired(true);

        $user->setEmail($data->email);
        $user->setPassword($this->passwordEncoder->encodePassword($user, $data->password));

        return $user;
    }

    public function supportsTransformation($data, string $to, array $context = []): bool
    {
        // in the case of an input, the value given here is an array (the JSON decoded).
        // if it's an event we transformed the data already
        if ($data instanceof User) {
            return false;
        }

        return User::class === $to && null !== ($context['input']['class'] ?? null);
    }
}

