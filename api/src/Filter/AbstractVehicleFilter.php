<?php

namespace App\Filter;

use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\AbstractContextAwareFilter;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Util\QueryNameGeneratorInterface;
use Doctrine\ORM\QueryBuilder;

abstract class AbstractVehicleFilter extends AbstractContextAwareFilter
{
    /**
     * @returns string|null
     */
    abstract function getVehicleAlias(QueryBuilder $queryBuilder, QueryNameGeneratorInterface $queryNameGenerator, string $resourceClass);

    protected function filterProperty(string $property, $value, QueryBuilder $queryBuilder, QueryNameGeneratorInterface $queryNameGenerator, string $resourceClass, string $operationName = null)
    {
        if($property != 'vehicle') {
            return;
        }

        if(!$value) return;

        $types = explode(',', $value);

        $rootAlias = $queryBuilder->getRootAliases()[0];

        $vehicleAlias = $this->getVehicleAlias($queryBuilder, $queryNameGenerator, $resourceClass);

        $queryBuilder
            ->leftJoin(sprintf('%s.parent', $vehicleAlias), 'v2')
            ->leftJoin('v2.parent', 'v3')
            ->leftJoin('v3.parent', 'v4')
            ->andWhere(sprintf('((%s.id IS NOT NULL AND %s.id IN (:types)) OR (v2.id IS NOT NULL AND v2.id IN (:types)) OR (v3.id IS NOT NULL AND v3.id IN (:types)) OR (v4.id IS NOT NULL AND v4.id IN (:types)))', $vehicleAlias, $vehicleAlias))
            ->setParameter('types', $types)
        ;
    }

    public function getDescription(string $resourceClass): array
    {
        if (!$this->properties) {
            return [];
        }

        $description = [];
        foreach ($this->properties as $property => $strategy) {
            $description["vehicle"] = [
                'property' => $property,
                'type' => 'string',
                'required' => false,
                'swagger' => [
                    'description' => 'Types of vehicle',
                    'name' => 'vehicle',
                    'type' => 'comma separated of vehicle types',
                ],
            ];
        }

        return $description;
    }
}