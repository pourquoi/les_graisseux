<?php

namespace App\Doctrine;

use ApiPlatform\Core\Bridge\Doctrine\Orm\Extension\QueryCollectionExtensionInterface;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Extension\QueryItemExtensionInterface;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Util\QueryNameGeneratorInterface;
use App\Entity\ChatMessage;
use App\Entity\ChatRoom;
use App\Entity\Job;
use App\Entity\JobApplication;
use Doctrine\ORM\QueryBuilder;
use Symfony\Component\Security\Core\Security;

class CurrentUserExtension implements QueryCollectionExtensionInterface, QueryItemExtensionInterface
{
    private $security;

    public function __construct(Security $security)
    {
        $this->security = $security;
    }

    public function applyToCollection(QueryBuilder $queryBuilder, QueryNameGeneratorInterface $queryNameGenerator, string $resourceClass, string $operationName = null): void
    {
        $this->addWhere($queryBuilder, $resourceClass, true);
    }

    public function applyToItem(QueryBuilder $queryBuilder, QueryNameGeneratorInterface $queryNameGenerator, string $resourceClass, array $identifiers, string $operationName = null, array $context = []): void
    {
        $this->addWhere($queryBuilder, $resourceClass);
    }

    private function addWhere(QueryBuilder $queryBuilder, string $resourceClass, bool $isCollection=false): void
    {
        $classes = [
            ChatRoom::class,
            ChatMessage::class,
            JobApplication::class,
            Job::class
        ];

        if (!in_array($resourceClass, $classes) || $this->security->isGranted('ROLE_ADMIN_BO') || null === $user = $this->security->getUser()) {
            return;
        }

        $rootAlias = $queryBuilder->getRootAliases()[0];

        switch($resourceClass) {
            case JobApplication::class:
                $queryBuilder
                    ->innerJoin(sprintf('%s.mechanic', $rootAlias), 'm')
                    ->innerJoin(sprintf('%s.job', $rootAlias), 'j')
                    ->innerJoin('j.customer', 'c')
                    ->andWhere('c.user = :user OR m.user = :user')
                    ->setParameter('user', $this->security->getUser());
                break;
            case Job::class:
                break;
        }
    }
}
