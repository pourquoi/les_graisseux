<?php

namespace App\Tests\Endpoints;

use ApiPlatform\Core\Bridge\Symfony\Bundle\Test\ApiTestCase;
use ApiPlatform\Core\Bridge\Symfony\Bundle\Test\Client;
use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;

abstract class Base extends ApiTestCase
{
    use RefreshDatabaseTrait;

    public static function login(Client $client, $email, $password)
    {
        $response = $client->request( 'POST', '/authentication_token', ['json' => [
            'email' => $email,
            'password' => $password
        ]]);

        $token = $response->toArray()['token'];

        $client->setDefaultOptions(['headers'=>[
            'Authorization' => 'Bearer ' . $token
        ]]);

        return $response->toArray();
    }
}
