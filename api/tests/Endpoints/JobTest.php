<?php

namespace App\Tests\Endpoints;

use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;
use Symfony\Component\HttpClient\Exception\ClientException;

class JobTest extends Base
{
    use RefreshDatabaseTrait;

    public function testGetCollection(): void
    {
        $response = static::createClient()->request('GET', '/api/jobs?page=1');
        $this->assertResponseIsSuccessful();

        $response = static::createClient()->request('GET', '/api/jobs?distance=0,0,10');
        $this->assertResponseIsSuccessful();
        $this->assertJsonContains(['hydra:totalItems' => 0]);

        $response = static::createClient()->request('GET', '/api/jobs?distance=48.867338,2.425216,1000');
        $this->assertResponseIsSuccessful();
        $this->assertJsonContains(['hydra:totalItems' => 2]);
    }
}
