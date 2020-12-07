<?php

namespace App\Serializer;

use App\Entity\Job;
use App\Entity\User;
use Symfony\Component\Security\Core\Exception\AuthenticationCredentialsNotFoundException;
use Symfony\Component\Security\Core\Security;
use Symfony\Component\Serializer\Normalizer\ContextAwareNormalizerInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerAwareInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerAwareTrait;

class JobNormalizer implements ContextAwareNormalizerInterface, NormalizerAwareInterface
{
    use NormalizerAwareTrait;
    private const ALREADY_CALLED = 'JOB_NORMALIZER_ALREADY_CALLED';
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

        return $data instanceof Job;
    }

    /**
     * @param Job $job
     * @param string|null $format
     * @param array $context
     * @return array|null
     * @throws
     */
    public function normalize($job, string $format = null, array $context = [])
    {
        $current_user = $this->security->getUser();

        try {
            if ($this->security->isGranted('ROLE_ADMIN') || ($current_user instanceof User && $current_user->getId() == $job->getCustomer()->getUser()->getId())) {
            }
        } catch(AuthenticationCredentialsNotFoundException $e) {
        }

        $context[self::ALREADY_CALLED] = true;

        return $this->normalizer->normalize($job, $format, $context);
    }

}
