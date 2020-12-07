<?php

namespace App\DataProvider;

use ApiPlatform\Core\DataProvider\ItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\RestrictedDataProviderInterface;
use App\Entity\Api\EmailVerification;

// just a wrapper for the query token
class EmailVerificationDataProvider implements ItemDataProviderInterface, RestrictedDataProviderInterface
{
    // $id is the token (but must be called "id" here due to api-platform internals)
    public function getItem(string $resourceClass, $id, string $operationName = null, array $context = [])
    {
        return new EmailVerification($id);
    }

    public function supports(string $resourceClass, string $operationName = null, array $context = []): bool
    {
        return EmailVerification::class === $resourceClass;
    }
}