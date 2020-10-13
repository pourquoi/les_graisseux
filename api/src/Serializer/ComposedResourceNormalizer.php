<?php

namespace App\Serializer;

use Symfony\Component\Serializer\Normalizer\DenormalizerInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerInterface;
use Symfony\Component\Serializer\SerializerAwareInterface;
use Symfony\Component\Serializer\SerializerInterface;

// @todo refactor
class ComposedResourceNormalizer implements NormalizerInterface, DenormalizerInterface, SerializerAwareInterface
{
    private $decorated;

    public function __construct(NormalizerInterface $decorated)
    {
        if (!$decorated instanceof DenormalizerInterface) {
            throw new \InvalidArgumentException(sprintf('The decorated normalizer must implement the %s.', DenormalizerInterface::class));
        }

        $this->decorated = $decorated;
    }

    public function supportsNormalization($data, string $format = null)
    {
        if( is_array($data) && isset($data['distance']) && isset($data[0]) ) {
            return $this->decorated->supportsNormalization($data[0], $format);
        }

        return $this->decorated->supportsNormalization($data, $format);
    }

    public function normalize($object, string $format = null, array $context = [])
    {
        if( is_array($object) && isset($object['distance']) && isset($object[0]) ) {
            $data = $this->decorated->normalize($object[0], $format, $context);

            foreach($object as $key=>$prop) {
                if( $key !== 0 && (is_scalar($prop) || is_string($prop))) {
                    $data['@' . $key] = $prop;
                }
            }
        } else {
            $data = $this->decorated->normalize($object, $format, $context);
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