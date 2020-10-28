<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Annotation\ApiSubresource;
use App\Repository\CustomerVehicleRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "customer_vehicle:read"}},
 *     denormalizationContext={"groups"={"write", "customer_vehicle:write"}},
 *     itemOperations={
 *       "get",
 *       "delete"={
 *         "method"="DELETE",
 *         "security"="is_granted('ROLE_ADMIN') or (is_granted('ROLE_CUSTOMER') and user.getCustomer() == object.getCustomer())"
 *       },
 *       "put"={
 *         "method"="PUT",
 *         "security"="is_granted('ROLE_ADMIN') or (is_granted('ROLE_CUSTOMER') and user.getCustomer() == object.getCustomer())"
 *       }
 *     },
 *     collectionOperations={
 *       "get",
 *       "post"={
 *         "method"="POST",
 *         "security"="is_granted('ROLE_ADMIN') or is_granted('ROLE_CUSTOMER')",
 *         "security_post_denormalize"="is_granted('ROLE_ADMIN') or (is_granted('ROLE_CUSTOMER') and user.getCustomer() == object.getCustomer())"
 *       }
 *     }
 * )
 * @ORM\Entity(repositoryClass=CustomerVehicleRepository::class)
 */
class CustomerVehicle
{
    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     * @Groups({"read", "write"})
     * @ApiProperty(writable=false)
     */
    protected $id;

    /**
     * @var Customer
     * @ORM\ManyToOne(targetEntity="Customer", inversedBy="vehicles")
     * @ORM\JoinColumn(nullable=false)
     * @Groups({"customer_vehicle:read", "write"})
     */
    protected $customer;

    /**
     * @var VehicleTree
     * @ORM\ManyToOne(targetEntity="VehicleTree")
     * @ORM\JoinColumn(nullable=false)
     * @Groups({"read", "write"})
     */
    protected $type;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getCustomer(): ?Customer
    {
        return $this->customer;
    }

    public function setCustomer(Customer $customer): self
    {
        $this->customer = $customer;
        return $this;
    }

    public function getType(): VehicleTree
    {
        return $this->type;
    }

    public function setType(VehicleTree $type): self
    {
        $this->type = $type;
        return $this;
    }
}
