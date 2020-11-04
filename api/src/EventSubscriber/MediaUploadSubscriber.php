<?php

namespace App\EventSubscriber;

use App\Entity\MediaObject;
use Liip\ImagineBundle\Service\FilterService;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Vich\UploaderBundle\Event\Events;
use Vich\UploaderBundle\Event\Event;

class MediaUploadSubscriber implements EventSubscriberInterface
{
    private $filterService;

    public function __construct(FilterService $filterService)
    {
        $this->filterService = $filterService;
    }

    public static function getSubscribedEvents()
    {
        return [
            Events::POST_UPLOAD => 'postInject'
        ];
    }

    public function postInject(Event $event)
    {
        /** @var MediaObject $media */
        $media = $event->getObject();

        // will generate the thumb
        $avatarUrl = $this->filterService->getUrlOfFilteredImage($media->getFilePath(), 'thumb');
    }

}