<?php

namespace App\Serializer;

use App\Entity\MediaObject;
use App\Entity\VehicleTree;
use Liip\ImagineBundle\Imagine\Cache\Resolver\ResolverInterface;
use Liip\ImagineBundle\Service\FilterService;
use Symfony\Component\Serializer\Normalizer\ContextAwareNormalizerInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerAwareInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerAwareTrait;
use Vich\UploaderBundle\Storage\StorageInterface;

class VehicleTreeNormalizer implements ContextAwareNormalizerInterface, NormalizerAwareInterface
{
    use NormalizerAwareTrait;
    private const ALREADY_CALLED = 'VEHICLE_NORMALIZER_ALREADY_CALLED';
    private $storage;
    private $filterService;

    public function __construct(StorageInterface $storage, FilterService $filterService)
    {
        $this->storage = $storage;
        $this->filterService = $filterService;
    }

    public function supportsNormalization($data, string $format = null, array $context = [])
    {
        if ($data instanceof VehicleTree) {
            if (isset($context[self::ALREADY_CALLED]) && in_array($data->getId(), $context[self::ALREADY_CALLED])) {
                return false;
            }
            return true;
        }

        return false;
    }

    /**
     * @param VehicleTree $object
     * @param string|null $format
     * @param array $context
     * @return array|null
     * @throws
     */
    public function normalize($object, string $format = null, array $context = [])
    {
        $context[self::ALREADY_CALLED][] = $object->getId();

        if ($object->getLogoPath()) {
            try {
                $object->logoUrl = $this->storage->resolveUri($object, 'logo');
            } catch (\Exception $e) {

            }

            try {
                $object->logoThumbUrl = $this->filterService->getUrlOfFilteredImage($object->getLogoPath(), 'brand_thumb', 'brand');
            } catch (\Exception $e) {

            }
        }

        $data = $this->normalizer->normalize($object, $format, $context);

        return $data;
    }
}