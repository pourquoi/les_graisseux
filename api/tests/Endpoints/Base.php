<?php

namespace App\Tests\Endpoints;

use ApiPlatform\Core\Bridge\Symfony\Bundle\Test\ApiTestCase;
use ApiPlatform\Core\Bridge\Symfony\Bundle\Test\Client;
use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;

abstract class Base extends ApiTestCase
{
    use RefreshDatabaseTrait;

    public static function login($client, $email, $password)
    {
        if ($client instanceof Client) {
            $response = $client->request('POST', '/authentication_token', ['json' => [
                'email' => $email,
                'password' => $password
            ]]);

            $token = $response->toArray()['token'];

            $client->setDefaultOptions(['headers' => [
                'Authorization' => 'Bearer ' . $token
            ]]);

            return $response->toArray();
        } else if ($client instanceof \Symfony\Bundle\FrameworkBundle\KernelBrowser) {
            $response = $client->request('POST', 'http://www.example.com/authentication_token', ['json' => [
                'email' => $email,
                'password' => $password
            ]]);

            $data = json_decode($client->getResponse()->getContent(), true);

            $client->setServerParameter('HTTP_AUTHORIZATION', 'Bearer ' . $data['token']);

            return $data;
        }

        throw new \InvalidArgumentException();
    }
}
