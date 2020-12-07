<?php

namespace App\Filter;

use ApiPlatform\Core\Bridge\Doctrine\Orm\Util\QueryNameGeneratorInterface;
use Doctrine\ORM\QueryBuilder;

class MechanicVehicleFilter extends AbstractVehicleFilter
{
    function getVehicleAlias(QueryBuilder $queryBuilder, QueryNameGeneratorInterface $queryNameGenerator, string $resourceClass)
    {
        $rootAlias = $queryBuilder->getRootAliases()[0];
        $queryBuilder->leftJoin(sprintf('%s.services', $rootAlias), 's')
            ->leftJoin('s.vehicle', 'v1');
        return 'v1';
    }
}