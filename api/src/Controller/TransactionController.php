<?php

namespace App\Controller;

use App\Entity\Api\EmailVerification;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class TransactionController extends AbstractController
{
    /**
     * Proxy to the api email verification controller.
     *
     * @Route("/_email_verification/{token}")
     * @param Request $request
     * @param EmailVerificationController $emailCtrl
     * @param string $token
     * @return Response
     */
    public function emailVerification(Request $request, EmailVerificationController $emailCtrl, $token): Response
    {
        return $emailCtrl(new EmailVerification($token), $request);
    }
}