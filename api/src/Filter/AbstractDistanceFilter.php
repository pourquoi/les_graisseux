<?php

namespace App\Filter;

use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\AbstractContextAwareFilter;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Util\QueryNameGeneratorInterface;
use Doctrine\ORM\QueryBuilder;
use Doctrine\Persistence\ManagerRegistry;
use Psr\Log\LoggerInterface;
use Symfony\Component\HttpFoundation\RequestStack;
use Symfony\Component\Serializer\NameConverter\NameConverterInterface;

abstract class AbstractDistanceFilter extends AbstractContextAwareFilter
{
    /**
     * @param QueryBuilder $queryBuilder
     * @param QueryNameGeneratorInterface $queryNameGenerator
     * @param string $resourceClass
     * @return string|null
     */
    abstract function getAddressAlias(QueryBuilder $queryBuilder, QueryNameGeneratorInterface $queryNameGenerator, string $resourceClass);

    protected function filterProperty(string $property, $value, QueryBuilder $queryBuilder, QueryNameGeneratorInterface $queryNameGenerator, string $resourceClass, string $operationName = null)
    {
        if ($property != 'distance') {
            return;
        }

        if (!$value) {
            return;
        }

        [$lat, $lng, $radius] = explode(',', $value);

        $addressAlias = $this->getAddressAlias($queryBuilder, $queryNameGenerator, $resourceClass);

        if( null === $addressAlias ) {
            return;
        }

        $queryBuilder->addSelect(
            '(
                  6371 * acos(
                    cos(radians(:lat)) * cos(radians(y('.$addressAlias.'.coordinates))) * cos(radians(x('.$addressAlias.'.coordinates)) - radians(:lng))
                    +
                    sin(radians(:lat)) * sin(radians(y('.$addressAlias.'.coordinates)))
                  )
                ) AS distance'
        )
            ->setParameter('lat', $lat)
            ->setParameter('lng', $lng)
            ->having('distance <= :radius')
            ->setParameter('radius', $radius)
        ;
    }

    public function getDescription(string $resourceClass): array
    {
        if (!$this->properties) {
            return [];
        }

        $description = [];
        foreach ($this->properties as $property => $strategy) {
            $description["distance"] = [
                'property' => $property,
                'type' => 'string',
                'required' => false,
                'swagger' => [
                    'description' => 'Maximum distance',
                    'name' => 'distance',
                    'type' => 'comma separated of lat, lng, radius',
                ],
            ];
        }

        return $description;
    }


}
