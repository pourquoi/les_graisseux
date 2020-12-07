<?php

namespace App\Filter;

use ApiPlatform\Core\Bridge\Doctrine\Orm\Util\QueryNameGeneratorInterface;
use Doctrine\ORM\QueryBuilder;
use Doctrine\Persistence\ManagerRegistry;
use Psr\Log\LoggerInterface;
use Symfony\Component\HttpFoundation\RequestStack;
use Symfony\Component\Serializer\NameConverter\NameConverterInterface;

final class JobDistanceFilter extends AbstractDistanceFilter
{
    function getAddressAlias(QueryBuilder $queryBuilder, QueryNameGeneratorInterface $queryNameGenerator, string $resourceClass)
    {
        $rootAlias = $queryBuilder->getRootAliases()[0];

        $customerAlias = $queryNameGenerator->generateJoinAlias("customer");
        $queryBuilder->innerJoin("${rootAlias}.customer", $customerAlias);

        $userAlias = $queryNameGenerator->generateJoinAlias("alias");
        $queryBuilder->innerJoin("${customerAlias}.user", $userAlias);

        $addressAlias = $queryNameGenerator->generateJoinAlias("address");
        $queryBuilder->innerJoin("${userAlias}.address", $addressAlias);

        return $addressAlias;
    }
}
