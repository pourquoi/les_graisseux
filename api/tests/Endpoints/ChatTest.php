<?php

namespace App\Tests\Endpoints;

use App\Entity\User;
use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;
use Symfony\Component\HttpClient\Exception\ClientException;

class ChatTest extends Base
{
    use RefreshDatabaseTrait;

    public function testGetCollection(): void
    {
        $response = static::createClient()->request('GET', '/api/chat_rooms?page=1');
        $this->assertEquals(401, $response->getStatusCode());

        $client = static::createClient();
        self::login($client, 'alice@example.com', 'pass1234');
        $response = $client->request('GET', '/api/chat_rooms?page=1');
        $this->assertResponseIsSuccessful();
        $this->assertJsonContains(['hydra:totalItems' => 2]);

        $client = static::createClient();
        self::login($client, 'roger@example.com', 'pass1234');
        $response = $client->request('GET', '/api/chat_rooms?page=1');
        $this->assertResponseIsSuccessful();
        $this->assertJsonContains(['hydra:totalItems' => 1]);
    }

    public function testCreateChat(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();

        $bob = $container->get('doctrine')->getRepository(User::class)->findOneByEmail('unverified@example.com');

        self::login($client, 'roger@example.com', 'pass1234');
        $response = $client->request('POST', '/api/chat_rooms', ['json'=>[
            'to' => $bob->getId(),
            'message' => 'Hey'
        ]]);
        $this->assertResponseIsSuccessful();
    }

    public function testReply(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();

        $client = static::createClient();
        self::login($client, 'roger@example.com', 'pass1234');
        $response = $client->request('GET', '/api/chat_rooms?page=1');
        $json = json_decode($response->getContent(), true);

        $uuid = $json['hydra:member'][0]['uuid'];

        $response = $client->request('POST', '/api/chat_messages', ['json'=>[
            'room' => $uuid,
            'message' => 'Hey'
        ]]);
        $this->assertResponseIsSuccessful();
    }
}
