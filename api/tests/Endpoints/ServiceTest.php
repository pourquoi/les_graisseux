<?php

namespace App\Tests\Endpoints;

use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;
use Hautelook\AliceBundle\PhpUnit\ReloadDatabaseTrait;
use Symfony\Component\HttpClient\Exception\ClientException;

class ServiceTest extends Base
{
    use ReloadDatabaseTrait;

    public function testGetCollection(): void
    {
        $response = static::createClient([], ['headers'=>['Accept-Language'=>'fr']])->request('GET', '/api/services');

        $this->assertResponseIsSuccessful();

        $this->assertJsonContains(['hydra:totalItems' => 7]);
    }

    public function testPostService(): void
    {
        $client = static::createClient();

        $response = $client->request('POST', '/api/services', ['json' => [
            'translations' => [
                'fr' => [
                    'locale' => 'fr',
                    'label' => 'Vidange',
                    'description' => 'Vidange, remplacement du filtre à huile ou filtre à air'
                ],
                'en' => [
                    'locale' => 'en',
                    'label' => 'Oil Change',
                    'description' => ''
                ]
            ]
        ]]);
        $this->assertResponseIsSuccessful();

        $service = $response->toArray();
        $response = $client->request('GET', $service['@id'], ['headers'=>['Accept-Language'=>'fr']]);
        $this->assertResponseIsSuccessful();

        $service = $response->toArray();
        $this->assertEquals('Vidange', $service['label']);

        $response = $client->request('GET', $service['@id'] . '?locale=en', ['headers'=>['Accept-Language'=>'en']]);
        $service = $response->toArray();
        $this->assertEquals('Oil Change', $service['label']);
    }
}
