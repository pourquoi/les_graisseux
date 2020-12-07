<?php

namespace App\Tests\Endpoints;

use ApiPlatform\Core\Bridge\Symfony\Bundle\Test\ApiTestCase;
use ApiPlatform\Core\Bridge\Symfony\Bundle\Test\Client;

abstract class Base extends ApiTestCase
{
    const UPLOAD_DIR = __DIR__ . '/../../public/test/upload';

    public static function login($client, $email, $password): array
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

    public static function logout($client): void
    {
        if ($client instanceof Client) {
            $client->setDefaultOptions(['headers' => []]);
        } else if ($client instanceof \Symfony\Bundle\FrameworkBundle\KernelBrowser) {
            $client->setServerParameters([]);
        }
    }
}
