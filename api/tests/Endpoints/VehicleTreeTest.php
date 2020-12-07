<?php

namespace App\Tests\Endpoints;

use App\Entity\Energy;
use App\Entity\VehicleTree;
use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;
use Hautelook\AliceBundle\PhpUnit\ReloadDatabaseTrait;
use Symfony\Component\HttpClient\Exception\ClientException;

class VehicleTreeTest extends Base
{
    use ReloadDatabaseTrait;

    public function test_listing(): void
    {
        $response = static::createClient()->request('GET', '/api/vehicles');

        $this->assertResponseIsSuccessful();

        $this->assertTrue($response->toArray()['hydra:totalItems'] > 0);
    }

    public function test_create_sequential(): void
    {
        $client = static::createClient();

        self::login($client, 'admin@example.com', 'pass1234');

        $response = $client->request('POST', '/api/vehicles', ['json'=>[
            'level' => 'brand',
            'name' => 'Alfa Romeo'
        ]]);
        $this->assertResponseIsSuccessful();
        $brand = $response->toArray();

        $response = $client->request('POST', '/api/vehicles', ['json'=>[
            'level' => 'family',
            'parent' => $brand['@id'],
            'name' => '159'
        ]]);
        $this->assertResponseIsSuccessful();
        $family = $response->toArray();

        $response = $client->request('POST', '/api/vehicles', ['json'=>[
            'level' => 'model',
            'parent' => $family['@id'],
            'name' => 'Berlina'
        ]]);
        $this->assertResponseIsSuccessful();
        $model = $response->toArray();

        $container = self::$kernel->getContainer();
        $energy = $container->get('doctrine')->getRepository(Energy::class)->findAll()[0];

        $response = $client->request('POST', '/api/vehicles', ['json'=>[
            'level' => 'type',
            'parent' => $model['@id'],
            'name' => '1.9 JTS 160cv',
            'energy' => "/api/energies/{$energy->getId()}"
        ]]);
        $this->assertResponseIsSuccessful();
    }

    public function test_create_full(): void
    {
        $client = static::createClient();

        self::login($client, 'admin@example.com', 'pass1234');

        $container = self::$kernel->getContainer();
        $energy = $container->get('doctrine')->getRepository(Energy::class)->findAll()[0];

        $response = $client->request('POST', '/api/vehicles', ['json'=>[
            'level' => 'type',
            'parent' => [
                'level' => 'model',
                'parent' => [
                    'level' => 'family',
                    'parent' => [
                        'level' => 'brand',
                        'name' => 'Alfa Romeo'
                    ],
                    'name' => '159'
                ],
                'name' => 'Berlina'
            ],
            'name' => '1.9 JTS 160cv',
            'energy' => "/api/energies/{$energy->getId()}"
        ]]);
        $this->assertResponseIsSuccessful();
    }
}
