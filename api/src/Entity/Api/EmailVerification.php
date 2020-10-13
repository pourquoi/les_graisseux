<?php

namespace App\Entity\Api;

use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use App\Controller\EmailVerificationController;

/**
 * @ApiResource(
 *     collectionOperations={},
 *     itemOperations={
 *         "get"={
 *             "method"="GET",
 *             "requirements"={"id"=".+"},
 *             "controller"=EmailVerificationController::class
 *         }
 *     },
 *     output=false
 * )
 */
class EmailVerification
{
    /**
     * @var string
     * @ApiProperty(identifier=true)
     */
    public $token;

    public function __construct($token)
    {
        $this->token = $token;
    }
}