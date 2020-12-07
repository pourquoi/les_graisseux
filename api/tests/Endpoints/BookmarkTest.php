<?php

namespace App\Tests\Endpoints;

use App\Entity\Bookmark;
use App\Entity\Job;
use App\Entity\User;
use App\Entity\UserVehicle;
use Hautelook\AliceBundle\PhpUnit\ReloadDatabaseTrait;

class BookmarkTest extends Base
{
    use ReloadDatabaseTrait;

    public function test_listing(): void
    {
        $client = static::createClient();
        $auth = self::login($client, 'alice@example.com', 'pass1234');
        $response = $client->request('GET', '/api/bookmarks?user=' . $auth['uid']);
        $this->assertResponseIsSuccessful();
    }

    public function test_bookmark_user(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();
        $user = $container->get('doctrine')->getRepository(User::class)->findOneByUsername('bob');

        $auth = self::login($client, 'alice@example.com', 'pass1234');
        $response = $client->request('POST', '/api/bookmarks', ['json' => [
            'user' => '/api/users/' . $user->getId(),
        ]]);
        $this->assertResponseIsSuccessful();
    }

    public function test_bookmark_job(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();
        $job = $container->get('doctrine')->getRepository(Job::class)->findBy([], null, 1)[0];

        $auth = self::login($client, 'alice@example.com', 'pass1234');
        $response = $client->request('POST', '/api/bookmarks', ['json' => [
            'job' => '/api/jobs/' . $job->getId(),
        ]]);
        $this->assertResponseIsSuccessful();
    }

    public function test_bookmark_vehicle(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();
        $vehicle = $container->get('doctrine')->getRepository(UserVehicle::class)->findBy([], null, 1)[0];

        $auth = self::login($client, 'alice@example.com', 'pass1234');
        $response = $client->request('POST', '/api/bookmarks', ['json' => [
            'vehicle' => '/api/user_vehicles/' . $vehicle->getId(),
        ]]);
        $this->assertResponseIsSuccessful();
    }

    public function test_bookmark_properties(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();
        $user = $container->get('doctrine')->getRepository(User::class)->findOneByUsername('alice');

        $bookmarked_user = $container->get('doctrine')->getRepository(User::class)->findOneByUsername('bob');
        $bookmarked_vehicle = $container->get('doctrine')->getRepository(UserVehicle::class)->findBy([], null, 1)[0];
        $bookmarked_job = $container->get('doctrine')->getRepository(Job::class)->findBy([], null, 1)[0];

        $bookmarks = [
            ((new Bookmark())->setUser($user)->setBookmarkedUser($bookmarked_user)),
            ((new Bookmark())->setUser($user)->setBookmarkedJob($bookmarked_job)),
            ((new Bookmark())->setUser($user)->setBookmarkedVehicle($bookmarked_vehicle))
        ];

        foreach($bookmarks as $bookmark)
            $container->get('doctrine')->getManager()->persist($bookmark);
        $container->get('doctrine')->getManager()->flush();

        $response = $client->request('GET', '/api/bookmarks?user=' . $user->getId());
        $this->assertResponseIsSuccessful();
        dd($response->toArray());
    }
}