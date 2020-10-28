<?php

namespace App\Tests\Endpoints;

use App\Entity\ServiceTree;
use App\Entity\VehicleTree;
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

    public function testPost(): void
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
        print_r($job);

        $job['tasks'] = array_map(function($task) {
            return $task['@id'];
        }, $job['tasks']);


        $response = $client->request('PUT', '/api/jobs/' . $job['id'], ['json'=>$job]);
        $this->assertResponseIsSuccessful();

        $job = $response->toArray();
    }
}
