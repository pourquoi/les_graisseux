<?php

namespace App\Filter;

use ApiPlatform\Core\Bridge\Doctrine\Orm\Util\QueryNameGeneratorInterface;
use Doctrine\ORM\QueryBuilder;

final class MechanicDistanceFilter extends AbstractDistanceFilter
{
    function getAddressAlias(QueryBuilder $queryBuilder, QueryNameGeneratorInterface $queryNameGenerator, string $resourceClass)
    {
        $rootAlias = $queryBuilder->getRootAliases()[0];

        $userAlias = $queryNameGenerator->generateJoinAlias("alias");
        $queryBuilder->leftJoin("${rootAlias}.user", $userAlias);

        $addressAlias = $queryNameGenerator->generateJoinAlias("address");
        $queryBuilder->leftJoin("${userAlias}.address", $addressAlias);

        return $addressAlias;
    }
}
