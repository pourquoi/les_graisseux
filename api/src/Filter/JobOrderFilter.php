<?php

namespace App\Filter;

use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\OrderFilter;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Util\QueryNameGeneratorInterface;
use Doctrine\ORM\QueryBuilder;

class JobOrderFilter extends OrderFilter
{
    protected function filterProperty(string $property, $direction, QueryBuilder $queryBuilder, QueryNameGeneratorInterface $queryNameGenerator, string $resourceClass, string $operationName = null)
    {
        if (!in_array($property, ['distance', 'hot', 'new'])) {
            return parent::filterProperty($property, $direction, $queryBuilder, $queryNameGenerator, $resourceClass, $operationName); // TODO: Change the autogenerated stub
        }

        $rootAlias = $queryBuilder->getRootAliases()[0];

        switch($property) {
            case 'distance':
                $queryBuilder->orderBy('distance', 'ASC');
                break;
            case 'new':
                $queryBuilder->orderBy(sprintf('%s.created_at', $rootAlias), 'DESC');
                break;
            case 'hot':
                $queryBuilder->orderBy(sprintf('%s.created_at', $rootAlias), 'ASC');
                break;
        }
    }
}
