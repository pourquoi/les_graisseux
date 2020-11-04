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

    public function testFilter(): void
    {
        $client = static::createClient();
        self::login($client, 'alice@example.com', 'pass1234');
        $response = $client->request('GET', '/api/chat_rooms?page=1');
        $this->assertResponseIsSuccessful();

        $room = $response->toArray()['hydra:member'][0];
        $response = $client->request('GET', '/api/chat_rooms/' . $room['uuid']);
        $this->assertResponseIsSuccessful();

        $response = $client->request('GET', '/api/chat_rooms/' . $room['uuid'] . '/messages');
        $this->assertResponseIsSuccessful();

        $response = $client->request('GET', '/api/chat_messages/feed');
        $this->assertResponseIsSuccessful();
    }

    public function testCreateChat(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();

        $bob = $container->get('doctrine')->getRepository(User::class)->findOneByEmail('bob@example.com');

        self::login($client, 'roger@example.com', 'pass1234');
        $response = $client->request('POST', '/api/chat_rooms', ['json'=>[
            'to' => '/api/users/' . $bob->getId(),
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

        $room = $json['hydra:member'][0];

        $response = $client->request('POST', '/api/chat_messages', ['json'=>[
            'room' => $room['@id'],
            'message' => 'Hey'
        ]]);
        $this->assertResponseIsSuccessful();

        $response = $client->request('POST', '/api/chat_messages', ['json'=>[
            'room' => $room['@id'],
            'message' => 'Hey2'
        ]]);
        $this->assertResponseIsSuccessful();
    }
}
