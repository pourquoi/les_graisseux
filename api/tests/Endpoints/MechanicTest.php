<?php

namespace App\Tests\Endpoints;

use App\Entity\ServiceTree;
use App\Entity\User;
use App\Entity\VehicleTree;
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
        $container = self::$kernel->getContainer();

        /** @var VehicleTree $vehicle */
        $vehicle = $container->get('doctrine')->getRepository(VehicleTree::class)->findAll()[0];
        /** @var ServiceTree $service */
        $service = $container->get('doctrine')->getRepository(ServiceTree::class)->findAll()[0];

        self::login($client, 'empty@example.com', 'pass1234');

        $response = $client->request('POST', '/api/mechanics', ['json'=>[
            'about' => 'hello',
            'address' => [
                'country' => 'FR',
                'locality' => 'Montreuil'
            ]
        ]]);
        $this->assertResponseIsSuccessful();

        $mechanic = json_decode($response->getContent(), true);

        $response = $client->request('POST', '/api/mechanic_services', ['json'=>[
            'skill' => 5,
            'service' => '/api/services/'.$service->getId(),
            'vehicle' => '/api/vehicles/'.$vehicle->getId(),
            'mechanic' => $mechanic['@id']
        ]]);
        $this->assertResponseIsSuccessful();
    }

    public function testCreateFull(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();

        /** @var VehicleTree $vehicle */
        $vehicle = $container->get('doctrine')->getRepository(VehicleTree::class)->findAll()[0];
        /** @var ServiceTree $service */
        $service = $container->get('doctrine')->getRepository(ServiceTree::class)->findAll()[0];

        self::login($client, 'empty@example.com', 'pass1234');

        $response = $client->request('POST', '/api/mechanics', ['json'=>[
            'about' => 'hello',
            'address' => [
                'country' => 'FR',
                'locality' => 'Montreuil'
            ],
            'services' => [
                [
                    'skill' => 5,
                    'service' => '/api/services/'.$service->getId(),
                    'vehicle' => '/api/vehicles/'.$vehicle->getId(),
                ]
            ]
        ]]);
        $this->assertResponseIsSuccessful();

        $mechanic = $response->toArray();
        $response = $client->request('PUT', '/api/mechanics/' . $mechanic['id'], ['json'=>[
            'about' => 'hello',
            'address' => [
                'country' => 'FR',
                'locality' => 'Montreuil'
            ],
            'services' => [
                [
                    'skill' => 6,
                    'service' => '/api/services/'.$service->getId(),
                    'vehicle' => '/api/vehicles/'.$vehicle->getId(),
                ]
            ]
        ]]);
        $this->assertResponseIsSuccessful();
        $mechanic = $response->toArray();
    }
}
