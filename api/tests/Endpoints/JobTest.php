<?php

namespace App\Tests\Endpoints;

use App\Entity\Job;
use App\Entity\ServiceTree;
use App\Entity\User;
use App\Entity\VehicleTree;
use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;
use Hautelook\AliceBundle\PhpUnit\ReloadDatabaseTrait;

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

        $response = static::createClient()->request('GET', '/api/jobs?distance=48.8673,2.425216,1000');
        $this->assertResponseIsSuccessful();
        $data = $response->toArray();
        $this->assertGreaterThan(0, $data['hydra:totalItems']);
    }

    public function testUserContext(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();
        $alice = $container->get('doctrine')->getRepository(User::class)->findOneByEmail('alice@example.com');

        $response = $client->request('GET', '/api/jobs?customer.user=' . $alice->getId());
        $this->assertResponseIsSuccessful();
        $data = $response->toArray();
        foreach($data['hydra:member'] as $job) {
            $this->assertNull($job['application']);
        }

        $data = self::login($client, 'bob@example.com', 'pass1234');
        $response = $client->request('GET', '/api/jobs?customer.user=' . $alice->getId());
        $this->assertResponseIsSuccessful();
        $data = $response->toArray();
        $applicationCount = 0;
        foreach($data['hydra:member'] as $job) {
            if (null !== $job['application'])
                $applicationCount++;
        }
        $this->assertGreaterThan(0, $applicationCount);
    }

    public function testCreate(): void
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

        $response = $client->request('POST', '/api/customer_vehicles', ['json'=>[
            'customer' => $user['customer']['@id'],
            'type' => '/api/vehicles/' . $vehicle->getId()
        ]]);

        $customer_vehicle = $response->toArray();

        $response = $client->request('POST', '/api/jobs', ['json'=>[
            'title' => 'job title',
            'description' => 'job description',
            'vehicle' => $customer_vehicle['@id'],
            'address' => [
                'country' => 'FR',
                'locality' => 'Montreuil',
                'postal_code' => 93100,
                'geocoordinates' => [0, 0]
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

    public function testApplyToJob(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();

        $customer = $container->get('doctrine')->getRepository(User::class)->findOneByEmail('alice@example.com')->getCustomer();

        $user = $container->get('doctrine')->getRepository(User::class)->findOneByEmail('roger@example.com');
        $job = $container->get('doctrine')->getRepository(Job::class)->findOneByCustomer($customer);

        self::login($client, 'roger@example.com', 'pass1234');

        $response = $client->request('GET', '/api/jobs');
        foreach($response->toArray()['hydra:member'] as $job) {
            if ($job['application'] == null) {
                break;
            }
        }
        $response = $client->request('POST', '/api/job_applications', ['json'=>[
            'mechanic' => '/api/mechanics/' . $user->getMechanic()->getId(),
            'job' => $job['@id']
        ]]);
        $this->assertResponseIsSuccessful();
    }
}
