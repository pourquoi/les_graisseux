<?php

namespace App\Filter;

use ApiPlatform\Core\Bridge\Doctrine\Orm\Util\QueryNameGeneratorInterface;
use Doctrine\ORM\QueryBuilder;

class JobVehicleFilter extends AbstractVehicleFilter
{
    function getVehicleAlias(QueryBuilder $queryBuilder, QueryNameGeneratorInterface $queryNameGenerator, string $resourceClass)
    {
        $rootAlias = $queryBuilder->getRootAliases()[0];
        $queryBuilder->leftJoin(sprintf('%s.vehicle', $rootAlias), 'v')
            ->leftJoin('v.type', 'v1');
        return 'v1';
    }
}