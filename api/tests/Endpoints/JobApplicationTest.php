<?php

namespace App\Tests\Endpoints;

use App\Entity\Job;
use App\Entity\ServiceTree;
use App\Entity\User;
use App\Entity\VehicleTree;
use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;
use Hautelook\AliceBundle\PhpUnit\ReloadDatabaseTrait;

class JobApplicationTest extends Base
{
    use RefreshDatabaseTrait;

    public function testGetMyApplication(): void
    {
        $client = static::createClient();
        $auth = self::login($client, 'bob@example.com', 'pass1234');

        $response = $client->request('GET', '/api/users/' . $auth['uid']);
        $user = $response->toArray();

        $response = $client->request('GET', '/api/job_applications?mechanic=' . $user['mechanic']['id']);

        $this->assertEquals(1, $response->toArray()['hydra:totalItems']);
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
