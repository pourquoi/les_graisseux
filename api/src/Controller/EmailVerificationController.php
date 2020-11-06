<?php

namespace App\Controller;

use App\Entity\Api\EmailVerification;
use App\Entity\User;
use App\Utils\TokenManager;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Twig\Environment;

class EmailVerificationController
{
    private $tokenManager;
    private $em;
    private $twig;

    public function __construct(TokenManager $tokenManager, EntityManagerInterface $em, Environment $twig)
    {
        $this->tokenManager = $tokenManager;
        $this->em = $em;
        $this->twig = $twig;
    }

    public function __invoke(EmailVerification $data, Request $request)
    {
        try {
            $data = $this->tokenManager->decode($data->token);
        } catch( \Exception $e ) {
            return new Response("invalid token", 400);
        }

        /** @var User $user */
        if( isset($data['user_id']) && ($user = $this->em->getRepository(User::class)->find($data['user_id'])) ) {
            $user->setEmailVerificationRequired(false);
            $this->em->flush();

            if (in_array('text/html', $request->getAcceptableContentTypes())) {
                return new Response($this->twig->render('transactions/email_verification.html.twig'));
            }

            return new Response("", 200);
        } else {
            return new Response("invalid token user", 400);
        }
    }
}