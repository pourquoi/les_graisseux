<?php

namespace App\Tests\Endpoints;

use App\Entity\Job;
use App\Entity\MediaObject;
use App\Entity\ServiceTree;
use App\Entity\User;
use App\Entity\VehicleTree;
use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;
use Hautelook\AliceBundle\PhpUnit\ReloadDatabaseTrait;

class JobTest extends Base
{
    use RefreshDatabaseTrait;

    /**
     * @group geocoding
     */
    public function test_listing(): void
    {
        $response = static::createClient()->request('GET', '/api/jobs?page=1');
        $this->assertResponseIsSuccessful();

        $response = static::createClient()->request('GET', '/api/jobs?distance=0,0,10');
        $this->assertResponseIsSuccessful();
        $this->assertJsonContains(['hydra:totalItems' => 0]);

        $response = static::createClient()->request('GET', '/api/jobs?distance=48.8673,2.425216,10');
        $this->assertResponseIsSuccessful();
        $data = $response->toArray();
        $this->assertGreaterThan(0, $data['hydra:totalItems']);

        $response = static::createClient()->request('GET', '/api/jobs?distance=48.8673,2.425216,2000&order[distance]');
        $this->assertResponseIsSuccessful();
        $data = $response->toArray();
        $this->assertGreaterThan(0, $data['hydra:totalItems']);

        $container = self::$kernel->getContainer();
        $brand = $container->get('doctrine')->getRepository(VehicleTree::class)->findOneBy(['level'=>VehicleTree::LEVEL_BRAND, 'name'=>'Alfa Romeo']);

        $response = static::createClient()->request('GET', '/api/jobs?vehicle='.$brand->getId());
        $this->assertResponseIsSuccessful();
    }

    public function test_job_properties(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();
        $alice = $container->get('doctrine')->getRepository(User::class)->findOneByEmail('alice@example.com');

        $response = $client->request('GET', '/api/jobs?customer.user=' . $alice->getId());
        $this->assertResponseIsSuccessful();
        $data = $response->toArray();

        foreach($data['hydra:member'] as $job) {
            $this->assertArrayHasKey('mine', $job);
            $this->assertFalse($job['mine']);
            $this->assertArrayHasKey('application', $job);
            $this->assertNull($job['application']);
        }

        $data = self::login($client, 'bob@example.com', 'pass1234');
        $response = $client->request('GET', '/api/jobs?customer.user=' . $alice->getId());
        $this->assertResponseIsSuccessful();
        $data = $response->toArray();
        $hasApplication = false;
        foreach($data['hydra:member'] as $job) {
            if (null !== $job['application']) {
                $hasApplication = true;
                break;
            }
        }
        $this->assertTrue($hasApplication);

        $response = $client->request('GET', '/api/jobs/' . $job['id']);
        $job = $response->toArray();
        $this->assertArrayHasKey('application', $job);
        $this->assertIsArray($job['application']);
    }

    public function test_create_job(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();

        /** @var VehicleTree $vehicle */
        $vehicle = $container->get('doctrine')->getRepository(VehicleTree::class)->findAll()[0];

        /** @var ServiceTree $task */
        $task = $container->get('doctrine')->getRepository(ServiceTree::class)->findAll()[0];

        $data = self::login($client, 'alice@example.com', 'pass1234');

        $response = $client->request('GET', '/api/users/' . $data['uid']);
        $user = $response->toArray();

        $response = $client->request('POST', '/api/user_vehicles', ['json'=>[
            'user' => $user['@id'],
            'type' => '/api/vehicles/' . $vehicle->getId()
        ]]);

        $customer_vehicle = $response->toArray();

        $picture = $container->get('doctrine')->getRepository(MediaObject::class)->findAll()[0];

        $response = $client->request('POST', '/api/jobs', ['json'=>[
            'title' => 'job title',
            'description' => 'job description',
            'vehicle' => $customer_vehicle['@id'],
            'address' => [
                'country' => 'FR',
                'locality' => 'Montreuil',
                'postal_code' => 93100,
                'geocoordinates' => [0, 0]
            ],
            'pictures' => [
                '/api/media_objects/' . $picture->getId()
            ]
        ]]);

        $this->assertResponseIsSuccessful();

        $response = $client->request('POST', '/api/jobs', ['json'=>[
            'title' => 'job title',
            'description' => 'job description',
            'vehicle' => [
                'km' => 100000,
                'type' => '/api/vehicles/' . $vehicle->getId()
            ],
            'tasks' => [
                '/api/services/' . $task->getId()
            ],
            'address' => [
                'country' => 'FR',
                'locality' => 'Montreuil',
                'postal_code' => 93100,
                'geocoordinates' => [0, 0]
            ]
        ]]);

        $this->assertResponseIsSuccessful();
        $job = $response->toArray();

        $job['tasks'] = array_map(function($task) {
            return $task['@id'];
        }, $job['tasks']);


        $response = $client->request('PUT', '/api/jobs/' . $job['id'], ['json'=>$job]);
        $this->assertResponseIsSuccessful();
    }
}
