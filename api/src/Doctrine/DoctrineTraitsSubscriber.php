<?php

namespace App\Doctrine;

use App\Entity\Traits\TimestampTrait;
use Doctrine\Common\EventSubscriber;
use Doctrine\ORM\Event\LifecycleEventArgs;
use Doctrine\ORM\Event\PreUpdateEventArgs;

class DoctrineTraitsSubscriber implements EventSubscriber
{
    public function getSubscribedEvents()
    {
        return [
            'prePersist',
            'preUpdate'
        ];
    }

    public function prePersist(LifecycleEventArgs $args)
    {
        $entity = $args->getEntity();
        $this->timestamp($entity);
    }

    public function preUpdate(PreUpdateEventArgs $args)
    {
        $this->timestamp($args->getEntity());
    }

    public function timestamp($entity)
    {
        if( $this->has_traits($entity, TimestampTrait::class) ) {
            /** @var TimestampTrait $entity */
            if( $entity->getCreatedAt() ) $entity->setUpdatedAt(new \DateTime());
            else $entity->setCreatedAt(new \DateTime());
        }
    }

    private function has_traits($entity, $trait_class)
    {
        try {
            $rc = new \ReflectionClass(get_class($entity));
        } catch( \ReflectionException $e ) {
            return false;
        }

        return array_key_exists( $trait_class, $rc->getTraits() );
    }
}