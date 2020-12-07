<?php

namespace App\DataTransformer;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use ApiPlatform\Core\Validator\ValidatorInterface;
use App\Dto;
use App\Entity\Bookmark;
use Symfony\Component\Security\Core\Security;

class BookmarkDataTransformer implements DataTransformerInterface
{
    private $security;
    private $validator;

    public function __construct(Security $security, ValidatorInterface $validator)
    {
        $this->security = $security;
        $this->validator = $validator;
    }

    /**
     * @param Dto\Input\Bookmark $data
     * @param string $to
     * @param array $context
     * @return Bookmark
     */
    public function transform($data, string $to, array $context = [])
    {
        $this->validator->validate($data);

        $bookmark = new Bookmark();
        $bookmark->setUser($this->security->getUser());

        if ($data->user) $bookmark->setBookmarkedUser($data->user);
        else if ($data->job) $bookmark->setBookmarkedJob($data->job);
        else if ($data->vehicle) $bookmark->setBookmarkedVehicle($data->vehicle);

        return $bookmark;
    }

    public function supportsTransformation($data, string $to, array $context = []): bool
    {
        if ($data instanceof Bookmark) {
            return false;
        }

        return $to === Bookmark::class && null !== ($context['input']['class'] ?? null);
    }

}