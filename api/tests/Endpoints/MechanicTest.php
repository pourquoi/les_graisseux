<?php

namespace App\Tests\Endpoints;

use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;
use Symfony\Component\HttpClient\Exception\ClientException;

class MechanicTest extends Base
{
    use RefreshDatabaseTrait;

    public function testGetCollection(): void
    {
        $response = static::createClient()->request('GET', '/api/mechanics?page=1');
        $this->assertResponseIsSuccessful();

        $response = static::createClient()->request('GET', '/api/mechanics?distance=0,0,10');
        $this->assertResponseIsSuccessful();
        $this->assertJsonContains(['hydra:totalItems' => 0]);

        $response = static::createClient()->request('GET', '/api/mechanics?distance=48.867338,2.425216,100');
        $this->assertResponseIsSuccessful();
        $this->assertJsonContains(['hydra:totalItems' => 1]);

        $json = json_decode($response->getContent(), true);
        $mechanic = $json['hydra:member'][0];

        $this->assertArrayHasKey('user', $mechanic);
    }

    public function testCreate(): void
    {
        $client = static::createClient();
        self::login($client, 'empty@example.com', 'pass1234');

        $response = $client->request('POST', '/api/mechanics', ['json'=>[
            'about' => 'hello'
        ]]);
        $this->assertResponseIsSuccessful();
    }
}
