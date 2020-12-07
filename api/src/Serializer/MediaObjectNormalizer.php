<?php

namespace App\Serializer;

use App\Entity\MediaObject;
use App\Entity\User;
use Liip\ImagineBundle\Service\FilterService;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
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
        if ($data instanceof MediaObject) {
            if (isset($context[self::ALREADY_CALLED]) && in_array($data->getId(), $context[self::ALREADY_CALLED])) {
                return false;
            }
            return true;
        }

        return false;
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
        $context[self::ALREADY_CALLED][] = $object->getId();

        try {
            $object->contentUrl = $this->storage->resolveUri($object, 'file');
        } catch( \Exception $e ) {
            return null;
        }

        try {
            $object->thumbUrl = $this->filterService->getUrlOfFilteredImage($object->getFilePath(), 'thumb');
        } catch( \Exception $e ) {
            return null;
        }

        $data = $this->normalizer->normalize($object, $format, $context);

        return $data;
    }

}
