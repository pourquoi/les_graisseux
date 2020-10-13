<?php

namespace App\DataProvider;

use ApiPlatform\Core\DataProvider\ItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\RestrictedDataProviderInterface;
use ApiPlatform\Core\Exception\ResourceClassNotSupportedException;
use App\Entity\Api\EmailVerification;

class EmailVerificationDataProvider implements ItemDataProviderInterface, RestrictedDataProviderInterface
{
    public function getItem(string $resourceClass, $id, string $operationName = null, array $context = [])
    {
        return new EmailVerification($id);
    }

    public function supports(string $resourceClass, string $operationName = null, array $context = []): bool
    {
        return EmailVerification::class === $resourceClass;
    }
}