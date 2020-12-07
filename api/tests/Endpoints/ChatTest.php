<?php

namespace App\Tests\Endpoints;

use App\Entity\ChatMessage;
use App\Entity\ChatRoom;
use App\Entity\Job;
use App\Entity\JobApplication;
use App\Entity\User;
use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;
use Hautelook\AliceBundle\PhpUnit\ReloadDatabaseTrait;
use Symfony\Component\HttpClient\Exception\ClientException;

class ChatTest extends Base
{
    use ReloadDatabaseTrait;

    public function test_room_listing_is_not_public(): void
    {
        $response = static::createClient()->request('GET', '/api/chat_rooms?page=1');
        $this->assertEquals(401, $response->getStatusCode());
    }

    public function test_room_listing_is_restricted_to_current_user(): void
    {
        $client = static::createClient();
        self::login($client, 'alice@example.com', 'pass1234');
        $response = $client->request('GET', '/api/chat_rooms?page=1');
        $this->assertResponseIsSuccessful();
        $this->assertJsonContains(['hydra:totalItems' => 3]);

        $client = static::createClient();
        self::login($client, 'roger@example.com', 'pass1234');
        $response = $client->request('GET', '/api/chat_rooms?page=1');
        $this->assertResponseIsSuccessful();
        $this->assertJsonContains(['hydra:totalItems' => 1]);
    }

    public function test_job_room_is_public(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();

        /** @var Job $job */
        $job = $container->get('doctrine')->getRepository(Job::class)->findAll()[0];

        self::login($client, 'alice@example.com', 'pass1234');
        $response = $client->request('GET', '/api/chat_rooms/' . $job->getChat()->getUuid());
        $this->assertResponseIsSuccessful();
    }

    public function test_application_room_is_private(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();

        /** @var JobApplication $application */
        $application = $container->get('doctrine')->getRepository(JobApplication::class)->findAll()[0];
        $url = '/api/chat_rooms/' . $application->getJob()->getChat()->getUuid();

        $response = $client->request('GET', $url);
        $this->assertEquals(401, $response->getStatusCode());

        self::login($client, $application->getMechanic()->getUser()->getEmail(), 'pass1234');
        $response = $client->request('GET', $url);
        $this->assertResponseIsSuccessful();

        self::login($client, $application->getJob()->getCustomer()->getUser()->getEmail(), 'pass1234');
        $response = $client->request('GET', $url);
        $this->assertResponseIsSuccessful();
    }

    /**
     * @group mercure
     */
    public function test_room_properties(): void
    {
        $client = static::createClient();
        self::login($client, 'alice@example.com', 'pass1234');
        $response = $client->request('GET', '/api/chat_rooms?page=1');
        $room = $response->toArray()['hydra:member'][0];
        $response = $client->request('GET', '/api/chat_rooms/' . $room['uuid']);
        $this->assertResponseIsSuccessful();
        $data = $response->toArray();
        $this->assertArrayHasKey('@subscription', $data);
        $this->assertArrayHasKey('title', $data);
        $this->assertArrayHasKey('last_message', $data);
    }

    public function test_job_room_messages_are_public(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();

        /** @var Job $job */
        $job = $container->get('doctrine')->getRepository(Job::class)->findAll()[0];
        $response = $client->request('GET', '/api/chat_messages?room.uuid=' . $job->getChat()->getUuid());
        $this->assertResponseIsSuccessful();
    }

    public function test_application_room_messages_are_private(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();

        /** @var JobApplication $application */
        $application = $container->get('doctrine')->getManager()->createQueryBuilder()
            ->select('a')->from(JobApplication::class, 'a')
            ->innerJoin('a.chat', 'chat')
            ->innerJoin('chat.messages', 'messages')
            ->where('messages.id IS NOT NULL')
            ->getQuery()->getResult()[0];
        $application_room = $application->getChat();

        $response = $client->request('GET', '/api/chat_messages?room.uuid=' . $application_room->getUuid());
        $data = $response->toArray();
        $this->assertTrue($data['hydra:totalItems'] == 0);

        self::login($client, $application->getMechanic()->getUser()->getEmail(), 'pass1234');
        $response = $client->request('GET', '/api/chat_messages?room.uuid=' . $application_room->getUuid());
        $data = $response->toArray();
        $this->assertTrue($data['hydra:totalItems'] > 0);
    }

    public function test_private_room_messages_are_private(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();

        $container->get('doctrine')->getManager()->clear();

        /** @var ChatRoom $private_room */
        $q = $container->get('doctrine')->getManager()->createQueryBuilder()
            ->select('chat')
            ->from(ChatRoom::class, 'chat')
            ->innerJoin('chat.messages', 'messages')
            ->leftJoin('chat.application', 'application')
            ->where('chat.private = 1')
            ->andWhere('application.id IS NULL')
            ->andWhere('messages.id IS NOT NULL')
            ->getQuery();

        $private_room = $q->getResult()[0];

        $response = $client->request('GET', '/api/chat_messages?room.uuid=' . $private_room->getUuid());
        $data = $response->toArray();
        $this->assertTrue($data['hydra:totalItems'] == 0);

        self::login($client, $private_room->getUsers()[0]->getUser()->getEmail(), 'pass1234');
        $response = $client->request('GET', '/api/chat_messages?room.uuid=' . $private_room->getUuid());
        $data = $response->toArray();

        $this->assertTrue($data['hydra:totalItems'] > 0);
    }

    public function test_users_can_pm_another_user(): void
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

    /**
     * @group mercure
     */
    public function test_users_can_reply(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();

        self::login($client, 'roger@example.com', 'pass1234');
        $response = $client->request('GET', '/api/chat_rooms?page=1');
        $json = json_decode($response->getContent(), true);

        $room = $json['hydra:member'][0];

        $response = $client->request('POST', '/api/chat_messages', ['json'=>[
            'room' => $room['@id'],
            'message' => 'Hey'
        ]]);
        $this->assertResponseIsSuccessful();
    }

    public function test_room_read_timestamp_is_updated(): void
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
        $room = $response->toArray();

        self::login($client, 'bob@example.com', 'pass1234');
        $response = $client->request('GET', '/api/chat_rooms/' . $room['uuid']);
        $room = $response->toArray();
        $this->assertArrayHasKey('unread_count', $room);
        $this->assertEquals(1, $room['unread_count']);

        $response = $client->request('GET', '/api/chat_rooms/' . $room['uuid']);
        $room = $response->toArray();
        $this->assertEquals(0, $room['unread_count']);
    }
}
