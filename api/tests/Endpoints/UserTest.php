<?php

namespace App\Tests\Endpoints;

use App\Entity\User;
use App\Repository\UserRepository;
use App\Utils\TokenManager;
use Hautelook\AliceBundle\PhpUnit\RefreshDatabaseTrait;
use Hautelook\AliceBundle\PhpUnit\ReloadDatabaseTrait;
use Lexik\Bundle\JWTAuthenticationBundle\Encoder\JWTEncoderInterface;
use Symfony\Bridge\Twig\Mime\TemplatedEmail;
use Symfony\Component\HttpClient\Exception\ClientException;
use Symfony\Component\Mailer\DataCollector\MessageDataCollector;
use Symfony\Component\Mailer\Event\MessageEvent;

class UserTest extends Base
{
    use ReloadDatabaseTrait;

    public function test_listing(): void
    {
        $response = static::createClient()->request('GET', '/api/users?username=bob');

        $this->assertResponseIsSuccessful();

        $this->assertJsonContains(['hydra:totalItems' => 1]);

        $user = json_decode($response->getContent(), true)['hydra:member'][0];

        $this->assertTrue($user['email'] == '');
    }

    /**
     * @group mercure
     */
    public function test_user_properties(): void
    {
        $client = static::createClient();
        $response = $client->request('GET', '/api/users?username=bob');
        $data = $response->toArray()['hydra:member'][0];
        $this->assertTrue($data['email'] == '');

        $response = $client->request('GET', $data['@id']);
        $data = $response->toArray();
        $this->assertTrue($data['email'] == '');

        self::login($client, 'bob@example.com', 'pass1234');
        $response = $client->request('GET', $data['@id']);
        $data = $response->toArray();
        $this->assertTrue($data['email'] != '');
        $this->assertArrayHasKey('@subscription', $data);
    }

    public function test_login(): void
    {
        $client = static::createClient();

        $response = $client->request( 'POST', '/authentication_token', ['json' => [
            'email' => 'bob@example.com',
            'password' => 'pass1234'
        ]]);
        $this->assertResponseIsSuccessful();
        $token = $response->toArray();
        $this->arrayHasKey('token');
        $this->assertNotEmpty($token['token']);
        $this->arrayHasKey('uid');
        $this->assertNotEmpty($token['uid']);

        $response = $client->request( 'POST', '/authentication_token', ['json' => [
            'email' => 'unverified@example.com',
            'password' => 'pass1234'
        ]]);
        $this->assertEquals(200, $response->getStatusCode());

        $response = $client->request( 'POST', '/authentication_token', ['json' => [
            'email' => 'bob@example.com',
            'password' => 'OOOOOOOOOOOOO'
        ]]);
        $this->assertEquals(401, $response->getStatusCode());

        $response = $client->request('GET', '/api/users?username=bob', ['headers'=>['Authorization'=>'Bearer 000000']]);
        $this->assertEquals(401, $response->getStatusCode());
    }

    public function test_email_verification(): void
    {
        $client = static::createClient();
        $container = self::$kernel->getContainer();
        /** @var User $user */
        $user = $container->get('doctrine')->getRepository(User::class)->findOneByEmail('unverified@example.com');
        $this->assertTrue($user->isEmailVerificationRequired());

        /** @var JWTEncoderInterface $encoder */
        $encoder = $container->get('lexik_jwt_authentication.encoder');
        $token = $encoder->encode(['user_id'=>$user->getId()]);

        $client->request('GET', '/api/email_verifications/' . $token);
        $this->assertResponseIsSuccessful();

        $container->get('doctrine')->getManager()->refresh($user);
        $this->assertFalse($user->isEmailVerificationRequired());

        $response = $client->request('GET', '/api/email_verifications/OOOOOOOOOOOOO');
        $this->assertEquals(400, $response->getStatusCode());
    }

    public function test_register(): void
    {
        $client = static::createClient();
        $client->enableProfiler();
        $container = self::$kernel->getContainer();

        $response = $client->request('POST', '/api/users', ['json' => [
            'email' => 'luke@example.com',
            'password' => 'pass1234'
        ]]);

        $user = $response->toArray();

        $this->assertResponseIsSuccessful();

        if ($profile = $client->getProfile()) {
            /** @var MessageDataCollector $collector */
            $collector = $profile->getCollector('mailer');
            $sent = 0;
            /** @var MessageEvent $event */
            foreach( $collector->getEvents()->getEvents() as $event) {
                if (!$event->isQueued()) $sent++;
            }
            $this->assertEquals(1, $sent);
        }

        $token = $container->get('lexik_jwt_authentication.encoder')->encode(['user_id' => $user['id']]);

        $response = $client->request('GET', '/_email_verification/' . $token, ['headers'=>['Accept' => 'text/html']]);
        $this->assertResponseIsSuccessful();
    }

    public function test_edit(): void
    {
        $client = static::createClient();
        $data = static::login($client, 'alice@example.com', 'pass1234');

        $response = $client->request('PATCH', '/api/users/' . $data['uid'], ['headers'=>['content-type'=>'application/merge-patch+json'], 'json' => [
            'username' => 'lapin'
        ]]);

        $this->assertResponseIsSuccessful();
    }
}
