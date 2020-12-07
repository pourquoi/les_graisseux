<?php

namespace App\Utils\Dataset;

interface ProviderContextInterface
{
    public function getProvidedAt(): \DateTimeInterface;

    public function getProviderKey(): string;

    public function getProviderVersion(): string;
}