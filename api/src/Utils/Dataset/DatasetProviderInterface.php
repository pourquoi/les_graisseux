<?php

namespace App\Utils\Dataset;

interface DatasetProviderInterface
{
    public function getKey() : string;

    public function getVersion() : string;

    public function update(): void;
}