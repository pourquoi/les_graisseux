<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiFilter;
use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Annotation\ApiSubresource;
use App\Repository\UserVehicleRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\SearchFilter;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "customer_vehicle:read"}},
 *     denormalizationContext={"groups"={"write", "customer_vehicle:write"}},
 *     itemOperations={
 *       "get",
 *       "delete"={
 *         "method"="DELETE",
 *         "security"="is_granted('ROLE_ADMIN') or (is_granted('ROLE_USER') and user == object.getUser())"
 *       },
 *       "put"={
 *         "method"="PUT",
 *         "security"="is_granted('ROLE_ADMIN') or (is_granted('ROLE_USER') and user == object.getUser())"
 *       }
 *     },
 *     collectionOperations={
 *       "get",
 *       "post"={
 *         "method"="POST",
 *         "security"="is_granted('ROLE_USER')",
 *         "security_post_denormalize"="is_granted('ROLE_ADMIN') or (is_granted('ROLE_USER') and user == object.getUser())"
 *       }
 *     }
 * )
 * @ORM\Entity(repositoryClass=UserVehicleRepository::class)
 * @ApiFilter(SearchFilter::class, properties={"user"})
 */
class UserVehicle
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
     * @var User
     * @ORM\ManyToOne(targetEntity="User", inversedBy="vehicles")
     * @ORM\JoinColumn(nullable=false)
     * @Groups({"customer_vehicle:read", "write"})
     */
    protected $user;

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

    public function getUser(): ?User
    {
        return $this->user;
    }

    public function setUser(User $user): self
    {
        $this->user = $user;
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
