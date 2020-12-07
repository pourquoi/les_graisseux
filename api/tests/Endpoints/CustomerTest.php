<?php

namespace App\Tests\Endpoints;

use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;
use Symfony\Component\HttpClient\Exception\ClientException;

class CustomerTest extends Base
{
    use RefreshDatabaseTrait;

    public function test_listing(): void
    {
        $response = static::createClient()->request('GET', '/api/customers?page=1');
        $this->assertResponseIsSuccessful();
        $this->assertJsonContains(['hydra:totalItems' => 12]);

        $json = json_decode($response->getContent(), true);
        $customer = $json['hydra:member'][0];

        $this->assertArrayHasKey('user', $customer);
    }

    public function test_create_customer(): void
    {
        $client = static::createClient();
        self::login($client, 'empty@example.com', 'pass1234');

        $response = $client->request('POST', '/api/customers', ['json'=>[]]);
        $this->assertResponseIsSuccessful();
    }
}
