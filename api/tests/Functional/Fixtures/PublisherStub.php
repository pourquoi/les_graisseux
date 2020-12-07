<?php

namespace App\Tests\Functional\Fixtures;

use Symfony\Component\Mercure\PublisherInterface;
use Symfony\Component\Mercure\Update;

class PublisherStub implements PublisherInterface
{
    public function __invoke(Update $update): string
    {
        return '';
    }
}