<?php

namespace App\Filter;

use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\OrderFilter;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Util\QueryNameGeneratorInterface;
use Doctrine\ORM\QueryBuilder;

class MechanicOrderFilter extends OrderFilter
{
    protected function filterProperty(string $property, $direction, QueryBuilder $queryBuilder, QueryNameGeneratorInterface $queryNameGenerator, string $resourceClass, string $operationName = null)
    {
        if (!in_array($property, ['distance'])) {
            return parent::filterProperty($property, $direction, $queryBuilder, $queryNameGenerator, $resourceClass, $operationName); // TODO: Change the autogenerated stub
        }

        $queryBuilder->orderBy('distance', 'ASC');
    }
}
