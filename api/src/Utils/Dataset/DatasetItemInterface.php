<?php

namespace App\Utils\Dataset;

use App\Entity\ProviderContext;

interface DatasetItemInterface
{
    public function getProviderContexts() : ?array;
}