<?php

namespace App\Serializer;

use App\Entity\MediaObject;
use App\Entity\User;
use Liip\ImagineBundle\Service\FilterService;
use Symfony\Component\Security\Core\Security;
use Symfony\Component\Serializer\Normalizer\ContextAwareNormalizerInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerAwareInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerAwareTrait;
use Vich\UploaderBundle\Storage\StorageInterface;

class MediaObjectNormalizer implements ContextAwareNormalizerInterface, NormalizerAwareInterface
{
    use NormalizerAwareTrait;
    private const ALREADY_CALLED = 'MEDIA_NORMALIZER_ALREADY_CALLED';
    private $storage;
    private $filterService;

    public function __construct(StorageInterface $storage, FilterService $filterService)
    {
        $this->storage = $storage;
        $this->filterService = $filterService;
    }

    public function supportsNormalization($data, string $format = null, array $context = [])
    {
        if (isset($context[self::ALREADY_CALLED])) {
            return false;
        }

        return $data instanceof MediaObject;
    }

    /**
     * @param MediaObject $object
     * @param string|null $format
     * @param array $context
     * @return array|null
     * @throws
     */
    public function normalize($object, string $format = null, array $context = [])
    {
        $context[self::ALREADY_CALLED] = true;

        $object->contentUrl = $this->storage->resolveUri($object, 'file');
        $object->thumbUrl = $this->filterService->getUrlOfFilteredImage($object->getFilePath(), 'thumb');

        $data = $this->normalizer->normalize($object, $format, $context);

        return $data;
    }

}
