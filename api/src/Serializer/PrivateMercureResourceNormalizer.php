<?php

namespace App\Serializer;

use ApiPlatform\Core\Api\IriConverterInterface;
use ApiPlatform\Core\Api\UrlGeneratorInterface;
use App\Entity\ChatRoom;
use App\Entity\User;
use Lcobucci\JWT\Builder;
use Lcobucci\JWT\Configuration;
use Lcobucci\JWT\Signer\Hmac\Sha256;
use Lcobucci\JWT\Signer\Key;
use Symfony\Component\Security\Core\Exception\AuthenticationCredentialsNotFoundException;
use Symfony\Component\Security\Core\Security;
use Symfony\Component\Serializer\Normalizer\DenormalizerInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerInterface;
use Symfony\Component\Serializer\SerializerAwareInterface;
use Symfony\Component\Serializer\SerializerInterface;

class PrivateMercureResourceNormalizer implements NormalizerInterface, DenormalizerInterface, SerializerAwareInterface
{
    private $decorated;
    private $iriConverter;
    private $security;
    private $configuration;

    public function __construct(NormalizerInterface $decorated, Security $security, IriConverterInterface $iriConverter, string $jwt_key)
    {
        if (!$decorated instanceof DenormalizerInterface) {
            throw new \InvalidArgumentException(sprintf('The decorated normalizer must implement the %s.', DenormalizerInterface::class));
        }

        $this->decorated = $decorated;
        $this->iriConverter = $iriConverter;
        $this->security = $security;

        $this->configuration = Configuration::forSymmetricSigner(
            new Sha256(),
            Key\InMemory::plainText($jwt_key)
        );
    }

    public function supportsNormalization($data, string $format = null)
    {
        return $this->decorated->supportsNormalization($data, $format);
    }

    public function normalize($object, string $format = null, array $context = [])
    {
        $data = $this->decorated->normalize($object, $format, $context);

        $context['groups'] = $context['groups'] ?? [];

        try {
            if (
                $this->security->isGranted('SUBSCRIBE', $object) &&
                ($context['item_operation_name'] ?? null) === 'get'
            ) {
                $iri = 'http://example.com' . $this->iriConverter->getIriFromItem($object, UrlGeneratorInterface::ABS_PATH);
                $token = $this->configuration->builder()
                    ->withClaim('mercure', ['subscribe' => [$iri]])
                    ->getToken($this->configuration->signer(), $this->configuration->signingKey());
                $data['@subscription'] = $token->toString();
            }
        } catch (AuthenticationCredentialsNotFoundException $e) {
        }

        return $data;
    }

    public function supportsDenormalization($data, $type, string $format = null)
    {
        return $this->decorated->supportsDenormalization($data, $type, $format);
    }

    public function denormalize($data, $class, string $format = null, array $context = [])
    {
        return $this->decorated->denormalize($data, $class, $format, $context);
    }

    public function setSerializer(SerializerInterface $serializer)
    {
        if($this->decorated instanceof SerializerAwareInterface) {
            $this->decorated->setSerializer($serializer);
        }
    }


}