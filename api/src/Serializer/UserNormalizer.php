<?php

namespace App\Serializer;

use App\Entity\User;
use Symfony\Component\Security\Core\Security;
use Symfony\Component\Serializer\Normalizer\ContextAwareNormalizerInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerAwareInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerAwareTrait;

class UserNormalizer implements ContextAwareNormalizerInterface, NormalizerAwareInterface
{
    use NormalizerAwareTrait;
    private const ALREADY_CALLED = 'USER_NORMALIZER_ALREADY_CALLED';
    private $security;

    public function __construct(Security $security)
    {
        $this->security = $security;
    }

    public function supportsNormalization($data, string $format = null, array $context = [])
    {
        if (isset($context[self::ALREADY_CALLED])) {
            return false;
        }

        return $data instanceof User;
    }

    public function normalize($object, string $format = null, array $context = [])
    {
        $current_user = $this->security->getUser();

        if ($this->security->isGranted('ROLE_ADMIN') || ($current_user instanceof User && $current_user->getId() == $object->getId())) {
            $context['groups'][] = 'owner:user:read';
        }

        $context[self::ALREADY_CALLED] = true;

        return $this->normalizer->normalize($object, $format, $context);
    }

}
